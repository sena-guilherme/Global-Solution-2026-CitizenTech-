namespace AgroSync.Api.Dtos;

public record LeituraSoloResponse(
    int Id, int AreaId, decimal UmidadePercentual, DateTime DataHora, string Origem, string? DispositivoId);