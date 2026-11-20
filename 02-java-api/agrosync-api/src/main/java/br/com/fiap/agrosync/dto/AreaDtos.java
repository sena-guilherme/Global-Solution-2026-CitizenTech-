package br.com.fiap.agrosync.dto;

import br.com.fiap.agrosync.domain.*;
import br.com.fiap.agrosync.dto.AlertaDtos.AlertaResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

public final class AreaDtos {

    private AreaDtos() {
    }

    public record CulturaRequest(
            @NotNull(message = "Informe o tipo (HORTALICA ou FRUTA)") TipoCultura tipo,
            @NotBlank(message = "Informe o nome da cultura") @Size(max = 80) String nome,
            @NotNull(message = "Informe a data de plantio") LocalDate dataPlantio,
            @NotNull(message = "Informe o estágio") Estagio estagio) {
    }

    public record AreaRequest(
            @NotBlank(message = "Informe o nome da área") @Size(max = 100) String nome,
            @NotNull(message = "Informe o tamanho em hectares") @Positive(message = "O tamanho deve ser maior que zero") Double tamanhoHa,
            @NotNull(message = "Informe a latitude")
            @DecimalMin(value = "-90.0", message = "Latitude entre -90 e 90")
            @DecimalMax(value = "90.0", message = "Latitude entre -90 e 90") Double latitude,
            @NotNull(message = "Informe a longitude")
            @DecimalMin(value = "-180.0", message = "Longitude entre -180 e 180")
            @DecimalMax(value = "180.0", message = "Longitude entre -180 e 180") Double longitude,
            @Valid CulturaRequest cultura) {
    }

    public record LeituraRequest(
            @NotNull(message = "Informe a umidade")
            @DecimalMin(value = "0.0", message = "A umidade deve estar entre 0 e 100")
            @DecimalMax(value = "100.0", message = "A umidade deve estar entre 0 e 100") Double valorUmidade,
            OrigemLeitura origem,
            @Size(max = 50, message = "Identificador do dispositivo muito longo") String idDispositivo) {
    }

    public record CulturaResponse(Long id, Long areaId, TipoCultura tipo, String nome, LocalDate dataPlantio,
                                  Estagio estagio) {
        public static CulturaResponse de(Cultura c) {
            return new CulturaResponse(c.getId(), c.getArea().getId(), c.getTipo(), c.getNome(), c.getDataPlantio(),
                    c.getEstagio());
        }
    }

    public record LeituraResponse(Long id, Long areaId, Double valorUmidade, LocalDateTime dataHora,
                                  OrigemLeitura origem, String idDispositivo, ClassificacaoUmidade classificacao) {
        public static LeituraResponse de(LeituraSolo l) {
            return new LeituraResponse(l.getId(), l.getArea().getId(), l.getValorUmidade(), l.getDataHora(),
                    l.getOrigem(), l.getIdDispositivo(), ClassificacaoUmidade.de(l.getValorUmidade()));
        }
    }

    public record AreaResponse(Long id, Long produtorId, String nome, Double tamanhoHa, Double latitude,
                               Double longitude, LocalDateTime dataCadastro, CulturaResponse cultura,
                               LeituraResponse ultimaLeitura, String recomendacao) {
        public static AreaResponse de(Area a, Cultura cultura, LeituraSolo leitura) {
            LeituraResponse ultima = leitura == null ? null : LeituraResponse.de(leitura);
            return new AreaResponse(a.getId(), a.getProdutor().getId(), a.getNome(), a.getTamanhoHa(), a.getLatitude(),
                    a.getLongitude(), a.getDataCadastro(),
                    cultura == null ? null : CulturaResponse.de(cultura), ultima,
                    ultima == null ? null : ultima.classificacao().getRecomendacao());
        }
    }

    public record LeituraRegistradaResponse(LeituraResponse leitura, AlertaResponse alerta) {
    }
}
