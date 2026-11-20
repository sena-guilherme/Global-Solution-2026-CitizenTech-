package br.com.fiap.agrosync.security;

import br.com.fiap.agrosync.repository.ProdutorRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/** Lê "Authorization: Bearer <token>", valida e autentica o produtor na requisição. */
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final ProdutorRepository produtores;
    private final PapelResolver papeis;

    public JwtAuthFilter(JwtService jwtService, ProdutorRepository produtores, PapelResolver papeis) {
        this.jwtService = jwtService;
        this.produtores = produtores;
        this.papeis = papeis;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String cabecalho = request.getHeader("Authorization");
        if (cabecalho != null && cabecalho.startsWith("Bearer ")
                && SecurityContextHolder.getContext().getAuthentication() == null) {
            jwtService.extrairEmail(cabecalho.substring(7))
                    .flatMap(produtores::findByEmailIgnoreCase)
                    .ifPresent(produtor -> {
                        UsuarioLogado usuario = UsuarioLogado.de(produtor, papeis.papelDe(produtor.getEmail()));
                        var auth = new UsernamePasswordAuthenticationToken(usuario, null, usuario.getAuthorities());
                        SecurityContextHolder.getContext().setAuthentication(auth);
                    });
        }
        chain.doFilter(request, response);
    }
}
