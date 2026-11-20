package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.exception.RegraNegocioException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;

/**
 * Guarda as fotos da comunidade em disco (pasta app.upload-dir).
 * A tabela PUBLICACAO não tem coluna de imagem, então a foto é ligada ao relato pelo NOME do arquivo:
 * pub-{id}.jpg|png|webp.
 */
@Service
public class ArmazenamentoService {

    private static final List<String> EXTENSOES = List.of("jpg", "jpeg", "png", "webp");

    private final Path raiz;

    public ArmazenamentoService(@Value("${app.upload-dir:uploads}") String pasta) {
        this.raiz = Paths.get(pasta).toAbsolutePath().normalize();
        try {
            Files.createDirectories(raiz);
        } catch (IOException e) {
            throw new UncheckedIOException("Não foi possível criar a pasta de uploads: " + raiz, e);
        }
    }

    /** Confere o formato ANTES de gravar o relato; devolve a extensão ou null se não houver arquivo. */
    public String validar(MultipartFile arquivo) {
        if (arquivo == null || arquivo.isEmpty()) {
            return null;
        }
        String original = StringUtils.cleanPath(arquivo.getOriginalFilename() == null ? "" : arquivo.getOriginalFilename());
        int ponto = original.lastIndexOf('.');
        String extensao = ponto >= 0 ? original.substring(ponto + 1).toLowerCase() : "";
        if (!EXTENSOES.contains(extensao)) {
            throw new RegraNegocioException("Formato de imagem não suportado. Envie JPG, PNG ou WEBP.");
        }
        return extensao;
    }

    public void salvar(Long publicacaoId, MultipartFile arquivo, String extensao) {
        if (extensao == null) {
            return;
        }
        try (InputStream in = arquivo.getInputStream()) {
            Files.copy(in, raiz.resolve("pub-" + publicacaoId + "." + extensao), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new UncheckedIOException("Falha ao salvar a imagem", e);
        }
    }

    /** Caminho público da foto do relato (ou null se o relato não tem foto). */
    public String urlDaPublicacao(Long publicacaoId) {
        for (String ext : EXTENSOES) {
            if (Files.exists(raiz.resolve("pub-" + publicacaoId + "." + ext))) {
                return "/uploads/pub-" + publicacaoId + "." + ext;
            }
        }
        return null;
    }

    public void remover(Long publicacaoId) {
        for (String ext : EXTENSOES) {
            try {
                Files.deleteIfExists(raiz.resolve("pub-" + publicacaoId + "." + ext));
            } catch (IOException ignorado) {
                // falha ao apagar o arquivo não deve impedir a exclusão do relato
            }
        }
    }
}
