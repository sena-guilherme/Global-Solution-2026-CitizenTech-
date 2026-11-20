package br.com.fiap.agrosync.repository;

import br.com.fiap.agrosync.domain.Area;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;

public interface AreaRepository extends JpaRepository<Area, Long>, JpaSpecificationExecutor<Area> {

    long countByProdutorId(Long produtorId);

    List<Area> findByProdutorIdOrderByNome(Long produtorId);
}
