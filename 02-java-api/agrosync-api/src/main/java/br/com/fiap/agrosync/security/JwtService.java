package br.com.fiap.agrosync.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Date;
import java.util.Optional;

@Service
public class JwtService {

    private final SecretKey chave;
    private final Duration validade;

    public JwtService(@Value("${app.jwt.secret}") String segredo,
                      @Value("${app.jwt.expiration-minutes}") long minutos) {
        byte[] bytes = segredo.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("app.jwt.secret precisa ter pelo menos 32 caracteres");
        }
        this.chave = Keys.hmacShaKeyFor(bytes);
        this.validade = Duration.ofMinutes(minutos);
    }

    public String gerar(UsuarioLogado usuario) {
        Date agora = new Date();
        return Jwts.builder()
                .subject(usuario.getEmail())
                .claim("papel", usuario.getPapel().name())
                .claim("nome", usuario.getNome())
                .issuedAt(agora)
                .expiration(new Date(agora.getTime() + validade.toMillis()))
                .signWith(chave)
                .compact();
    }

    public long validadeEmSegundos() {
        return validade.toSeconds();
    }

    /** Devolve o e-mail (subject) se o token for válido e não estiver expirado. */
    public Optional<String> extrairEmail(String token) {
        try {
            Claims claims = Jwts.parser().verifyWith(chave).build().parseSignedClaims(token).getPayload();
            return Optional.ofNullable(claims.getSubject());
        } catch (JwtException | IllegalArgumentException e) {
            return Optional.empty();
        }
    }
}
