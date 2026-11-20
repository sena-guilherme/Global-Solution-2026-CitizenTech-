package br.com.fiap.agrosync.repository;

import br.com.fiap.agrosync.domain.Publicacao;
import org.jspecify.annotations.NonNull;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface PublicacaoRepository extends JpaRepository<Publicacao, Long>, JpaSpecificationExecutor<Publicacao> {

    // Carrega o autor junto, evitando uma consulta extra por relato no feed
    @Override
    @EntityGraph(attributePaths = "produtor")
    Page<Publicacao> findAll(Specification<Publicacao> spec, @NonNull Pageable pageable);
}
