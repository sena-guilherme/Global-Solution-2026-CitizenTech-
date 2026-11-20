package br.com.fiap.agrosync.repository;

import br.com.fiap.agrosync.domain.Produtor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProdutorRepository extends JpaRepository<Produtor, Long> {

    // Query methods derivados do nome do método
    Optional<Produtor> findByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCase(String email);
}
