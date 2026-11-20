package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.domain.*;
import br.com.fiap.agrosync.dto.AlertaDtos.AlertaResponse;
import br.com.fiap.agrosync.dto.AreaDtos.LeituraRegistradaResponse;
import br.com.fiap.agrosync.dto.AreaDtos.LeituraRequest;
import br.com.fiap.agrosync.dto.AreaDtos.LeituraResponse;
import br.com.fiap.agrosync.exception.RegraNegocioException;
import br.com.fiap.agrosync.repository.CulturaRepository;
import br.com.fiap.agrosync.repository.LeituraSoloRepository;
import br.com.fiap.agrosync.security.UsuarioLogado;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LeituraService {

    private final LeituraSoloRepository leituras;
    private final CulturaRepository culturas;
    private final AreaService areaService;
    private final AlertaService alertaService;

    @Transactional
    public LeituraRegistradaResponse registrar(Long areaId, LeituraRequest req, UsuarioLogado usuario) {
        Area area = areaService.carregar(areaId, usuario);
        Cultura cultura = culturaAtual(area);

        LeituraSolo l = new LeituraSolo();
        l.setArea(area);
        l.setValorUmidade(req.valorUmidade());
        l.setOrigem(req.origem() == null ? OrigemLeitura.MANUAL : req.origem());
        l.setIdDispositivo(req.idDispositivo() == null || req.idDispositivo().isBlank() ? null : req.idDispositivo().trim());
        LeituraSolo salva = leituras.save(l);

        ClassificacaoUmidade classificacao = ClassificacaoUmidade.de(req.valorUmidade());
        Alerta alerta = alertaService.gerarPorUmidade(cultura, req.valorUmidade(), classificacao);
        return new LeituraRegistradaResponse(LeituraResponse.de(salva), AlertaResponse.de(alerta));
    }

    @Transactional(readOnly = true)
    public Page<LeituraResponse> listar(Long areaId, UsuarioLogado usuario, Pageable pageable) {
        areaService.carregar(areaId, usuario); // valida existência e permissão
        return leituras.findByAreaIdOrderByDataHoraDescIdDesc(areaId, pageable).map(LeituraResponse::de);
    }

    @Transactional
    public AlertaResponse registrarIrrigacao(Long areaId, UsuarioLogado usuario) {
        Area area = areaService.carregar(areaId, usuario);
        return AlertaResponse.de(alertaService.gerarIrrigacao(culturaAtual(area)));
    }

    private Cultura culturaAtual(Area area) {
        return culturas.findFirstByAreaIdOrderByDataPlantioDescIdDesc(area.getId())
                .orElseThrow(() -> new RegraNegocioException(
                        "A área " + area.getId() + " não possui cultura cadastrada."));
    }
}
