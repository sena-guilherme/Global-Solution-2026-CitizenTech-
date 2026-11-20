package br.com.fiap.agrosync.repository;

import br.com.fiap.agrosync.domain.Cultura;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CulturaRepository extends JpaRepository<Cultura, Long> {

    List<Cultura> findByAreaIdOrderByDataPlantioDescIdDesc(Long areaId);

    Optional<Cultura> findFirstByAreaIdOrderByDataPlantioDescIdDesc(Long areaId);

    List<Cultura> findByAreaProdutorRegiaoIgnoreCase(String regiao);
}
