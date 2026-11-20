package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.domain.*;
import br.com.fiap.agrosync.dto.AlertaDtos.AlertaRequest;
import br.com.fiap.agrosync.dto.AlertaDtos.AlertaResponse;
import br.com.fiap.agrosync.exception.RecursoNaoEncontradoException;
import br.com.fiap.agrosync.exception.RegraNegocioException;
import br.com.fiap.agrosync.repository.AlertaRepository;
import br.com.fiap.agrosync.repository.CulturaRepository;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.spec.AlertaSpecs;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AlertaService {

    private final AlertaRepository alertas;
    private final CulturaRepository culturas;

    @Transactional(readOnly = true)
    public Page<AlertaResponse> listar(UsuarioLogado usuario, TipoAlerta tipo, Severidade severidade, Boolean lido,
                                       Pageable pageable) {
        Specification<Alerta> spec = AlertaSpecs.visivelPara(usuario)
                .and(AlertaSpecs.tipo(tipo))
                .and(AlertaSpecs.severidade(severidade))
                .and(AlertaSpecs.lido(lido));
        return alertas.findAll(spec, pageable).map(AlertaResponse::de);
    }

    @Transactional(readOnly = true)
    public long contarNaoLidos(UsuarioLogado usuario) {
        return alertas.countByCulturaAreaProdutorIdAndLidoFalse(usuario.getId());
    }

    @Transactional
    public AlertaResponse marcarLido(Long id, UsuarioLogado usuario) {
        Alerta a = alertas.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Alerta não encontrado."));
        if (!usuario.isAdmin() && !a.getCultura().getArea().getProdutor().getId().equals(usuario.getId())) {
            throw new AccessDeniedException("Alerta de outro produtor");
        }
        a.setLido(true);
        return AlertaResponse.de(a);
    }

    /** Administrador cria um alerta para uma cultura, para uma região ou para todas as culturas. */
    @Transactional
    public List<AlertaResponse> criar(AlertaRequest req) {
        List<Cultura> destino;
        if (req.idCultura() != null) {
            destino = List.of(culturas.findById(req.idCultura())
                    .orElseThrow(() -> new RecursoNaoEncontradoException("Cultura destinatária não encontrada.")));
        } else if (req.regiao() != null && !req.regiao().isBlank()) {
            destino = culturas.findByAreaProdutorRegiaoIgnoreCase(req.regiao().trim());
        } else {
            destino = culturas.findAll();
        }
        if (destino.isEmpty()) {
            throw new RegraNegocioException("Não há culturas cadastradas para receber o alerta.");
        }
        return destino.stream()
                .map(c -> alertas.save(novo(c, req.tipo(), req.severidade(), req.mensagem().trim())))
                .map(AlertaResponse::de)
                .toList();
    }

    @Transactional
    public void excluir(Long id) {
        if (!alertas.existsById(id)) {
            throw new RecursoNaoEncontradoException("Alerta não encontrado.");
        }
        alertas.deleteById(id);
    }

    /**
     * Regra de negócio central (igual à do banco): gera o alerta de UMIDADE conforme a classificação da leitura.
     * CRITICO &lt; 20 | MODERADO &lt; 35 | NORMAL até 70 | EXCESSO &gt; 70 (alerta com severidade NORMAL).
     */
    @Transactional
    public Alerta gerarPorUmidade(Cultura cultura, double umidade, ClassificacaoUmidade classificacao) {
        String valor = BigDecimal.valueOf(umidade).stripTrailingZeros().toPlainString();
        String base = "Umidade do solo em " + valor + "% - ";
        String nome = cultura.getNome();
        String mensagem = switch (classificacao) {
            case CRITICO -> base + "irrigacao urgente para " + nome;
            case MODERADO -> base + "irrigar nas proximas 24h para " + nome;
            case EXCESSO -> base + "solo encharcado, suspender irrigacao para " + nome;
            default -> base + "dentro da faixa ideal para " + nome;
        };
        return alertas.save(novo(cultura, TipoAlerta.UMIDADE, classificacao.getSeveridadeDoAlerta(), mensagem));
    }

    @Transactional
    public Alerta gerarIrrigacao(Cultura cultura) {
        String mensagem = "Irrigacao manual registrada na area " + cultura.getArea().getNome() + " (" + cultura.getNome() + ")";
        return alertas.save(novo(cultura, TipoAlerta.IRRIGACAO, Severidade.NORMAL, mensagem));
    }

    private Alerta novo(Cultura cultura, TipoAlerta tipo, Severidade severidade, String mensagem) {
        Alerta a = new Alerta();
        a.setCultura(cultura);
        a.setTipo(tipo);
        a.setSeveridade(severidade);
        a.setMensagem(mensagem.length() > 255 ? mensagem.substring(0, 255) : mensagem);
        return a;
    }
}
