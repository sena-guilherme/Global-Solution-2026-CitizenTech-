package br.com.fiap.agrosync.spec;

import br.com.fiap.agrosync.domain.Alerta;
import br.com.fiap.agrosync.domain.Severidade;
import br.com.fiap.agrosync.domain.TipoAlerta;
import br.com.fiap.agrosync.security.UsuarioLogado;
import org.springframework.data.jpa.domain.Specification;

public final class AlertaSpecs {

    private AlertaSpecs() {
    }

    /** O alerta pertence ao produtor dono da área da cultura (ALERTA -> CULTURA -> AREA -> PRODUTOR). */
    public static Specification<Alerta> visivelPara(UsuarioLogado usuario) {
        return (root, query, cb) -> usuario.isAdmin()
                ? null
                : cb.equal(root.get("cultura").get("area").get("produtor").get("id"), usuario.getId());
    }

    public static Specification<Alerta> tipo(TipoAlerta tipo) {
        return (root, query, cb) -> tipo == null ? null : cb.equal(root.get("tipo"), tipo);
    }

    public static Specification<Alerta> severidade(Severidade severidade) {
        return (root, query, cb) -> severidade == null ? null : cb.equal(root.get("severidade"), severidade);
    }

    public static Specification<Alerta> lido(Boolean lido) {
        return (root, query, cb) -> lido == null ? null : cb.equal(root.get("lido"), lido);
    }
}
