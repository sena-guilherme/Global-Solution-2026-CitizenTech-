package br.com.fiap.agrosync.dto;

import br.com.fiap.agrosync.domain.Papel;
import br.com.fiap.agrosync.security.UsuarioLogado;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class AuthDtos {

    private AuthDtos() {
    }

    public record RegistroRequest(
            @NotBlank(message = "Informe o nome") @Size(max = 100, message = "Nome muito longo") String nome,
            @NotBlank(message = "Informe o e-mail") @Email(message = "E-mail inválido") @Size(max = 150) String email,
            @NotBlank(message = "Informe a senha") @Size(min = 6, max = 72, message = "A senha deve ter de 6 a 72 caracteres") String senha,
            @NotBlank(message = "Informe o município") @Size(max = 80) String municipio,
            @NotBlank(message = "Informe a região") @Size(max = 60) String regiao) {
    }

    public record LoginRequest(
            @NotBlank(message = "Informe o e-mail") @Email(message = "E-mail inválido") String email,
            @NotBlank(message = "Informe a senha") String senha) {
    }

    public record ProdutorResponse(Long id, String nome, String email, String municipio, String regiao, Papel papel) {
        public static ProdutorResponse de(UsuarioLogado u) {
            return new ProdutorResponse(u.getId(), u.getNome(), u.getEmail(), u.getMunicipio(), u.getRegiao(), u.getPapel());
        }
    }

    public record AuthResponse(String token, String tipo, long expiraEmSegundos, ProdutorResponse usuario) {
    }
}
