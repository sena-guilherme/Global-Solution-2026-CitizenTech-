package br.com.fiap.agrosync.service;

import br.com.fiap.agrosync.domain.Area;
import br.com.fiap.agrosync.domain.Cultura;
import br.com.fiap.agrosync.dto.AreaDtos.CulturaRequest;
import br.com.fiap.agrosync.dto.AreaDtos.CulturaResponse;
import br.com.fiap.agrosync.exception.RecursoNaoEncontradoException;
import br.com.fiap.agrosync.repository.CulturaRepository;
import br.com.fiap.agrosync.security.UsuarioLogado;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CulturaService {

    private final CulturaRepository culturas;
    private final AreaService areaService;

    @Transactional(readOnly = true)
    public List<CulturaResponse> listar(Long areaId, UsuarioLogado usuario) {
        areaService.carregar(areaId, usuario);
        return culturas.findByAreaIdOrderByDataPlantioDescIdDesc(areaId).stream().map(CulturaResponse::de).toList();
    }

    @Transactional
    public CulturaResponse adicionar(Long areaId, CulturaRequest req, UsuarioLogado usuario) {
        Area area = areaService.carregar(areaId, usuario);
        Cultura c = new Cultura();
        c.setArea(area);
        AreaService.aplicarCultura(c, req);
        return CulturaResponse.de(culturas.save(c));
    }

    @Transactional
    public CulturaResponse atualizar(Long id, CulturaRequest req, UsuarioLogado usuario) {
        Cultura c = carregar(id, usuario);
        AreaService.aplicarCultura(c, req);
        return CulturaResponse.de(c);
    }

    @Transactional
    public void excluir(Long id, UsuarioLogado usuario) {
        culturas.delete(carregar(id, usuario));
    }

    private Cultura carregar(Long id, UsuarioLogado usuario) {
        Cultura c = culturas.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Cultura não encontrada."));
        if (!usuario.isAdmin() && !c.getArea().getProdutor().getId().equals(usuario.getId())) {
            throw new AccessDeniedException("Cultura de outro produtor");
        }
        return c;
    }
}
