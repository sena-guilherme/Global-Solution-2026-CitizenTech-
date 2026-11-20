package br.com.fiap.agrosync.spec;

import br.com.fiap.agrosync.domain.Publicacao;
import org.springframework.data.jpa.domain.Specification;

public final class PublicacaoSpecs {

    private PublicacaoSpecs() {
    }

    public static Specification<Publicacao> regiao(String regiao) {
        return (root, query, cb) -> (regiao == null || regiao.isBlank())
                ? null
                : cb.equal(cb.lower(root.get("regiao")), regiao.trim().toLowerCase());
    }

    /** Busca livre no texto, na cultura, na região ou no nome do produtor. */
    public static Specification<Publicacao> busca(String termo) {
        return (root, query, cb) -> {
            if (termo == null || termo.isBlank()) {
                return null;
            }
            String like = "%" + termo.trim().toLowerCase() + "%";
            return cb.or(
                    cb.like(cb.lower(root.get("texto")), like),
                    cb.like(cb.lower(root.get("cultura")), like),
                    cb.like(cb.lower(root.get("regiao")), like),
                    cb.like(cb.lower(root.get("produtor").get("nome")), like));
        };
    }
}
