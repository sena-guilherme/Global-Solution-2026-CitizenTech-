package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.domain.Produtor;
import br.com.fiap.agrosync.dto.AuthDtos.*;
import br.com.fiap.agrosync.exception.RegraNegocioException;
import br.com.fiap.agrosync.repository.ProdutorRepository;
import br.com.fiap.agrosync.security.JwtService;
import br.com.fiap.agrosync.security.PapelResolver;
import br.com.fiap.agrosync.security.UsuarioLogado;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final ProdutorRepository produtores;
    private final PasswordEncoder encoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final PapelResolver papeis;

    @Transactional
    public AuthResponse registrar(RegistroRequest req) {
        String email = req.email().trim().toLowerCase();
        if (produtores.existsByEmailIgnoreCase(email)) {
            throw new RegraNegocioException("Já existe uma conta com este e-mail.");
        }
        Produtor p = new Produtor();
        p.setNome(req.nome().trim());
        p.setEmail(email);
        p.setSenha(encoder.encode(req.senha()));
        p.setMunicipio(req.municipio().trim());
        p.setRegiao(req.regiao().trim());
        return resposta(produtores.save(p));
    }

    @Transactional
    public AuthResponse login(LoginRequest req) {
        String email = req.email().trim().toLowerCase();
        // Lança BadCredentialsException (401) se e-mail ou senha estiverem errados
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(email, req.senha()));
        Produtor p = produtores.findByEmailIgnoreCase(email).orElseThrow();
        if (!p.getSenha().startsWith("$2")) {
            // senha de teste em texto puro (carga do script do banco): passa a ser guardada com BCrypt
            p.setSenha(encoder.encode(req.senha()));
        }
        return resposta(p);
    }

    private AuthResponse resposta(Produtor p) {
        UsuarioLogado u = UsuarioLogado.de(p, papeis.papelDe(p.getEmail()));
        return new AuthResponse(jwtService.gerar(u), "Bearer", jwtService.validadeEmSegundos(), ProdutorResponse.de(u));
    }
}
