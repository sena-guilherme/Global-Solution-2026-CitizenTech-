package br.com.fiap.agrosync.spec;

import br.com.fiap.agrosync.domain.Area;
import br.com.fiap.agrosync.security.UsuarioLogado;
import org.springframework.data.jpa.domain.Specification;

public final class AreaSpecs {

    private AreaSpecs() {
    }
    public static Specification<Area> visivelPara(UsuarioLogado usuario) {
        return (root, query, cb) -> usuario.isAdmin() ? null : cb.equal(root.get("produtor").get("id"), usuario.getId());
    }

    public static Specification<Area> nome(String nome) {
        return (root, query, cb) -> (nome == null || nome.isBlank())
                ? null
                : cb.like(cb.lower(root.get("nome")), "%" + nome.trim().toLowerCase() + "%");
    }
}
