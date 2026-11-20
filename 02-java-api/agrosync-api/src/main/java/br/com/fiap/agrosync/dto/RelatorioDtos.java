package br.com.fiap.agrosync.dto;

import br.com.fiap.agrosync.domain.ClassificacaoUmidade;
import br.com.fiap.agrosync.domain.Estagio;

import java.util.List;

public final class RelatorioDtos {

    private RelatorioDtos() {
    }

    public record RelatorioResponse(Long produtorId, String produtor, String municipio, long qtdAreas, long totalAlertas,
                                    long alertasCriticos, List<LinhaArea> areas) {
    }

    public record LinhaArea(Long areaId, String area, String cultura, Estagio estagio, Double ultimaUmidade,
                            ClassificacaoUmidade classificacao) {
    }
}
