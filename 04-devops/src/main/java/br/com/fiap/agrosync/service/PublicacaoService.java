package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.domain.Publicacao;
import br.com.fiap.agrosync.dto.PublicacaoDtos.PublicacaoForm;
import br.com.fiap.agrosync.dto.PublicacaoDtos.PublicacaoResponse;
import br.com.fiap.agrosync.exception.RecursoNaoEncontradoException;
import br.com.fiap.agrosync.repository.ProdutorRepository;
import br.com.fiap.agrosync.repository.PublicacaoRepository;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.spec.PublicacaoSpecs;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PublicacaoService {

    private final PublicacaoRepository publicacoes;
    private final ProdutorRepository produtores;
    private final ArmazenamentoService armazenamento;

    @Transactional(readOnly = true)
    public Page<PublicacaoResponse> listar(String regiao, String busca, Pageable pageable) {
        Specification<Publicacao> spec = PublicacaoSpecs.regiao(regiao).and(PublicacaoSpecs.busca(busca));
        return publicacoes.findAll(spec, pageable).map(this::resposta);
    }

    @Transactional
    public PublicacaoResponse criar(PublicacaoForm form, UsuarioLogado usuario) {
        String extensao = armazenamento.validar(form.getImagem()); // falha antes de gravar o relato
        Publicacao p = new Publicacao();
        p.setProdutor(produtores.findById(usuario.getId()).orElseThrow());
        p.setTexto(form.getTexto().trim());
        p.setCultura(form.getCultura().trim());
        p.setRegiao(form.getRegiao().trim());
        Publicacao salva = publicacoes.save(p);
        armazenamento.salvar(salva.getId(), form.getImagem(), extensao);
        return resposta(salva);
    }

    @Transactional
    public PublicacaoResponse confirmar(Long id) {
        Publicacao p = buscar(id);
        p.setConfirmacoes(p.getConfirmacoes() + 1);
        return resposta(p);
    }

    @Transactional
    public PublicacaoResponse desfazerConfirmacao(Long id) {
        Publicacao p = buscar(id);
        p.setConfirmacoes(Math.max(0, p.getConfirmacoes() - 1));
        return resposta(p);
    }

    @Transactional
    public void excluir(Long id, UsuarioLogado usuario) {
        Publicacao p = buscar(id);
        if (!usuario.isAdmin() && !p.getProdutor().getId().equals(usuario.getId())) {
            throw new AccessDeniedException("Só o autor ou um administrador pode excluir o relato.");
        }
        publicacoes.delete(p);
        armazenamento.remover(id);
    }

    private Publicacao buscar(Long id) {
        return publicacoes.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Relato não encontrado."));
    }

    private PublicacaoResponse resposta(Publicacao p) {
        return PublicacaoResponse.de(p, armazenamento.urlDaPublicacao(p.getId()));
    }
}
