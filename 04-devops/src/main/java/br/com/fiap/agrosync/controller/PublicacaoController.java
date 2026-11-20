package br.com.fiap.agrosync.controller;

import br.com.fiap.agrosync.dto.PublicacaoDtos.PublicacaoForm;
import br.com.fiap.agrosync.dto.PublicacaoDtos.PublicacaoResponse;
import br.com.fiap.agrosync.security.UsuarioLogado;
import br.com.fiap.agrosync.service.PublicacaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/publicacoes")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Comunidade", description = "Feed de relatos dos produtores, com foto opcional")
public class PublicacaoController {

    private final PublicacaoService service;

    @Operation(summary = "Feed da comunidade com filtro por região e busca por texto, cultura, região ou produtor")
    @GetMapping
    public Page<PublicacaoResponse> listar(@RequestParam(required = false) String regiao,
                                           @RequestParam(required = false) String busca,
                                           @PageableDefault(size = 10, sort = "dataPublicacao", direction = Sort.Direction.DESC) Pageable pageable) {
        return service.listar(regiao, busca, pageable);
    }

    @Operation(summary = "Publica um relato (multipart/form-data: texto, cultura, regiao e imagem opcional)")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PublicacaoResponse> criar(@Valid @ModelAttribute PublicacaoForm form,
                                                    @AuthenticationPrincipal UsuarioLogado usuario) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.criar(form, usuario));
    }

    @Operation(summary = "Confirma o relato como útil (soma 1 em confirmacoes)")
    @PostMapping("/{id}/confirmar")
    public PublicacaoResponse confirmar(@PathVariable Long id) {
        return service.confirmar(id);
    }

    @Operation(summary = "Desfaz uma confirmação (subtrai 1, nunca abaixo de zero)")
    @DeleteMapping("/{id}/confirmar")
    public PublicacaoResponse desfazerConfirmacao(@PathVariable Long id) {
        return service.desfazerConfirmacao(id);
    }

    @Operation(summary = "Exclui o relato (somente o autor ou um administrador)")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@PathVariable Long id, @AuthenticationPrincipal UsuarioLogado usuario) {
        service.excluir(id, usuario);
    }
}
