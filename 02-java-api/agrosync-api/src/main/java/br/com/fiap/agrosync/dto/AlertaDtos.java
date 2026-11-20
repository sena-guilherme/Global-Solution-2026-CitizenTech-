package br.com.fiap.agrosync.dto;

import br.com.fiap.agrosync.domain.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public final class AlertaDtos {

    private AlertaDtos() {
    }

    public record AlertaRequest(
            @NotNull(message = "Informe o tipo") TipoAlerta tipo,
            @NotNull(message = "Informe a severidade") Severidade severidade,
            @NotBlank(message = "Informe a mensagem") @Size(max = 255, message = "A mensagem deve ter até 255 caracteres") String mensagem,
            Long idCultura,
            @Size(max = 60) String regiao) {
    }

    public record AlertaResponse(Long id, Long culturaId, String culturaNome, String areaNome, TipoAlerta tipo,
                                 Severidade severidade, String mensagem, boolean lido, LocalDateTime dataGeracao,
                                 String recomendacao) {

        public static AlertaResponse de(Alerta a) {
            Cultura c = a.getCultura();
            return new AlertaResponse(a.getId(), c.getId(), c.getNome(), c.getArea().getNome(), a.getTipo(),
                    a.getSeveridade(), a.getMensagem(), a.isLido(), a.getDataGeracao(),
                    recomendacaoDe(a.getTipo(), a.getSeveridade(), a.getMensagem()));
        }

        static String recomendacaoDe(TipoAlerta tipo, Severidade severidade, String mensagem) {
            if (tipo == TipoAlerta.UMIDADE) {
                if (mensagem != null && mensagem.toLowerCase().contains("encharcado")) {
                    return ClassificacaoUmidade.EXCESSO.getRecomendacao();
                }
                return switch (severidade) {
                    case CRITICO -> ClassificacaoUmidade.CRITICO.getRecomendacao();
                    case MODERADO -> ClassificacaoUmidade.MODERADO.getRecomendacao();
                    default -> ClassificacaoUmidade.NORMAL.getRecomendacao();
                };
            }
            if (tipo == TipoAlerta.IRRIGACAO) {
                return severidade == Severidade.NORMAL
                        ? "Irrigação registrada. Acompanhe a umidade nas próximas leituras."
                        : "Confira o programa de irrigação da área.";
            }
            return switch (severidade) {
                case CRITICO -> "Proteja a lavoura hoje e acompanhe a previsão do tempo.";
                case MODERADO -> "Planeje a proteção da lavoura para as próximas horas.";
                default -> "Sem ação necessária. Acompanhe a previsão do tempo.";
            };
        }
    }
}
