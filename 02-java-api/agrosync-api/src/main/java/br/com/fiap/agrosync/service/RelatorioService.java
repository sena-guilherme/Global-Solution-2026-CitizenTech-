package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.domain.Area;
import br.com.fiap.agrosync.domain.ClassificacaoUmidade;
import br.com.fiap.agrosync.domain.Cultura;
import br.com.fiap.agrosync.domain.LeituraSolo;
import br.com.fiap.agrosync.domain.Produtor;
import br.com.fiap.agrosync.dto.RelatorioDtos.LinhaArea;
import br.com.fiap.agrosync.dto.RelatorioDtos.RelatorioResponse;
import br.com.fiap.agrosync.exception.RecursoNaoEncontradoException;
import br.com.fiap.agrosync.repository.*;
import br.com.fiap.agrosync.security.UsuarioLogado;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RelatorioService {

    private final ProdutorRepository produtores;
    private final AreaRepository areas;
    private final CulturaRepository culturas;
    private final LeituraSoloRepository leituras;
    private final AlertaRepository alertas;

    @Transactional(readOnly = true)
    public RelatorioResponse gerar(Long produtorId, UsuarioLogado usuario) {
        if (!usuario.isAdmin() && !usuario.getId().equals(produtorId)) {
            throw new AccessDeniedException("Relatório de outro produtor");
        }
        Produtor p = produtores.findById(produtorId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Produtor não encontrado."));

        List<LinhaArea> linhas = areas.findByProdutorIdOrderByNome(produtorId).stream().map(this::linha).toList();
        return new RelatorioResponse(p.getId(), p.getNome(), p.getMunicipio(),
                areas.countByProdutorId(produtorId),
                alertas.contarPorProdutor(produtorId),
                alertas.contarCriticosPorProdutor(produtorId),
                linhas);
    }

    private LinhaArea linha(Area a) {
        Cultura c = culturas.findFirstByAreaIdOrderByDataPlantioDescIdDesc(a.getId()).orElse(null);
        LeituraSolo l = leituras.findFirstByAreaIdOrderByDataHoraDescIdDesc(a.getId()).orElse(null);
        return new LinhaArea(a.getId(), a.getNome(),
                c == null ? null : c.getNome(),
                c == null ? null : c.getEstagio(),
                l == null ? null : l.getValorUmidade(),
                l == null ? null : ClassificacaoUmidade.de(l.getValorUmidade()));
    }
}
