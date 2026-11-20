package br.com.fiap.agrosync.controller;

import br.com.fiap.agrosync.dto.AuthDtos.*;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Autenticação", description = "Cadastro de produtor, login (JWT) e dados do usuário logado")
public class AuthController {

    private final AuthService service;

    @Operation(summary = "Cadastra um novo produtor (tabela PRODUTOR) e já devolve o token JWT")
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> registrar(@Valid @RequestBody RegistroRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.registrar(req));
    }

    @Operation(summary = "Autentica com e-mail e senha e devolve o token JWT")
    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest req) {
        return service.login(req);
    }

    @Operation(summary = "Dados do produtor autenticado", security = @SecurityRequirement(name = "bearerAuth"))
    @GetMapping("/me")
    public ProdutorResponse me(@AuthenticationPrincipal UsuarioLogado usuario) {
        return ProdutorResponse.de(usuario);
    }
}
