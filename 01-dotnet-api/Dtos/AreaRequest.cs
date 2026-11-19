using System.ComponentModel.DataAnnotations;

namespace AgroSync.Api.Dtos;

public class AreaRequest
{
    [Required(ErrorMessage = "O nome da área é obrigatório.")]
    [StringLength(100, ErrorMessage = "O nome deve ter no máximo 100 caracteres.")]
    public string Nome { get; set; } = string.Empty;

    [Range(0.01, 100000.0, ErrorMessage = "O tamanho deve estar entre 0,01 e 100000 hectares.")]
    public decimal TamanhoHectares { get; set; }

    [Range(-90.0, 90.0, ErrorMessage = "A latitude deve estar entre -90 e 90.")]
    public decimal Latitude { get; set; }

    [Range(-180.0, 180.0, ErrorMessage = "A longitude deve estar entre -180 e 180.")]
    public decimal Longitude { get; set; }
}