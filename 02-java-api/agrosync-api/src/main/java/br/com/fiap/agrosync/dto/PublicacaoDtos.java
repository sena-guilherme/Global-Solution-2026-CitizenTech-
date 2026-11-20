package br.com.fiap.agrosync.dto;

import br.com.fiap.agrosync.domain.Publicacao;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

public final class PublicacaoDtos {

    private PublicacaoDtos() {
    }

    @Getter
    @Setter
    public static class PublicacaoForm {
        @NotBlank(message = "Escreva o relato")
        @Size(min = 10, max = 500, message = "O relato deve ter entre 10 e 500 caracteres")
        private String texto;

        @NotBlank(message = "Informe a cultura")
        @Size(max = 80, message = "Cultura muito longa")
        private String cultura;

        @NotBlank(message = "Informe a região")
        @Size(max = 60, message = "Região muito longa")
        private String regiao;

        private MultipartFile imagem;
    }

    public record PublicacaoResponse(Long id, Long autorId, String autor, String cultura, String regiao, String texto,
                                     String imagemUrl, int confirmacoes, LocalDateTime dataHora) {
        public static PublicacaoResponse de(Publicacao p, String imagemUrl) {
            return new PublicacaoResponse(p.getId(), p.getProdutor().getId(), p.getProdutor().getNome(), p.getCultura(),
                    p.getRegiao(), p.getTexto(), imagemUrl, p.getConfirmacoes(), p.getDataPublicacao());
        }
    }
}
