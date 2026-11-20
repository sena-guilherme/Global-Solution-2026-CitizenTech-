package br.com.fiap.agrosync.repository;

import br.com.fiap.agrosync.domain.LeituraSolo;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LeituraSoloRepository extends JpaRepository<LeituraSolo, Long> {

    Page<LeituraSolo> findByAreaIdOrderByDataHoraDescIdDesc(Long areaId, Pageable pageable);

    Optional<LeituraSolo> findFirstByAreaIdOrderByDataHoraDescIdDesc(Long areaId);
}
