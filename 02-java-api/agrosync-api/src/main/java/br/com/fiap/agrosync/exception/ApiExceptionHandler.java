package br.com.fiap.agrosync.exception;

import br.com.fiap.agrosync.dto.ErroResposta;
import br.com.fiap.agrosync.dto.ErroResposta.CampoErro;
import org.jspecify.annotations.NonNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.InvalidDataAccessApiUsageException;
import org.springframework.data.mapping.PropertyReferenceException;
import org.springframework.http.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.ServletWebRequest;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.time.LocalDateTime;
import java.util.List;

@RestControllerAdvice
public class ApiExceptionHandler extends ResponseEntityExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

    @ExceptionHandler(RecursoNaoEncontradoException.class)
    public ResponseEntity<Object> naoEncontrado(RecursoNaoEncontradoException ex, WebRequest req) {
        return montar(HttpStatus.NOT_FOUND, ex.getMessage(), req, null);
    }

    @ExceptionHandler(RegraNegocioException.class)
    public ResponseEntity<Object> regraNegocio(RegraNegocioException ex, WebRequest req) {
        return montar(HttpStatus.CONFLICT, ex.getMessage(), req, null);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Object> acessoNegado(AccessDeniedException ex, WebRequest req) {
        return montar(HttpStatus.FORBIDDEN, "Você não tem permissão para esta ação.", req, null);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<Object> naoAutenticado(AuthenticationException ex, WebRequest req) {
        return montar(HttpStatus.UNAUTHORIZED, "E-mail ou senha inválidos.", req, null);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Object> integridade(DataIntegrityViolationException ex, WebRequest req) {
        log.warn("Violação de integridade: {}", ex.getMostSpecificCause().getMessage());
        return montar(HttpStatus.CONFLICT, "Operação não permitida: o registro viola uma regra de integridade dos dados.", req, null);
    }

    /** Ordenação por campo inexistente (?sort=xyz). */
    @ExceptionHandler({PropertyReferenceException.class, InvalidDataAccessApiUsageException.class})
    public ResponseEntity<Object> parametroInvalido(Exception ex, WebRequest req) {
        return montar(HttpStatus.BAD_REQUEST, "Parâmetro de consulta ou ordenação inválido.", req, null);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> inesperado(Exception ex, WebRequest req) {
        log.error("Erro inesperado", ex);
        return montar(HttpStatus.INTERNAL_SERVER_ERROR, "Erro interno do servidor.", req, null);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex, @NonNull HttpHeaders headers,
                                                                  @NonNull HttpStatusCode status, @NonNull WebRequest request) {
        List<CampoErro> campos = ex.getBindingResult().getFieldErrors().stream()
                .map((FieldError f) -> new CampoErro(f.getField(), f.getDefaultMessage()))
                .toList();
        return montar(HttpStatus.BAD_REQUEST, "Dados inválidos.", request, campos);
    }

    @Override
    protected ResponseEntity<Object> handleExceptionInternal(@NonNull Exception ex, Object body, @NonNull HttpHeaders headers,
                                                             HttpStatusCode status, @NonNull WebRequest request) {
        String mensagem = switch (status.value()) {
            case 400 -> "Requisição inválida. Confira os dados enviados.";
            case 404 -> "Recurso não encontrado.";
            case 405 -> "Método HTTP não permitido para este endereço.";
            case 413 -> "Arquivo muito grande. O limite é de 5 MB.";
            case 415 -> "Tipo de conteúdo não suportado.";
            default -> ex.getMessage();
        };
        return montar(HttpStatus.valueOf(status.value()), mensagem, request, null);
    }

    private ResponseEntity<Object> montar(HttpStatus status, String mensagem, WebRequest req, List<CampoErro> campos) {
        String path = req instanceof ServletWebRequest swr ? swr.getRequest().getRequestURI() : "";
        ErroResposta corpo = new ErroResposta(LocalDateTime.now(), status.value(), status.getReasonPhrase(),
                mensagem, path, campos);
        return ResponseEntity.status(status).contentType(MediaType.APPLICATION_JSON).body(corpo);
    }
}
