import maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import length from '@turf/length';
import along from '@turf/along';
import bearing from '@turf/bearing';

export default {
  mounted() {
    this.shipMarkers = {};
    this.routeData = null;
    this.shipsToRender = null;
    this.mapLoaded = false;

    // 1. Initialize Map
    this.map = new maplibregl.Map({
      container: this.el,
      style: {
        version: 8,
        sources: {
          'world': {
            type: 'vector',
            url: 'https://demotiles.maplibre.org/tiles/tiles.json'
          }
        },
        layers: [
          {
            id: 'background',
            type: 'background',
            paint: { 'background-color': '#050b14' }
          },
          {
            id: 'land',
            type: 'fill',
            source: 'world',
            'source-layer': 'countries',
            paint: {
              'fill-color': '#112240',
              'fill-outline-color': '#1a365d'
            }
          }
        ]
      },
      center: [2, 53],
      zoom: 4,
      interactive: true
    });

    // 2. Fetch Route Data immediately
    const routesUrl = this.el.dataset.routes;
    fetch(routesUrl)
      .then(response => response.json())
      .then(data => {
        this.routeData = data;
        this.checkReady();
      })
      .catch(e => console.error("Failed to load routes.json", e));

    // 3. Handle Initial Ship Data
    if (this.el.dataset.initialShips) {
      this.shipsToRender = JSON.parse(this.el.dataset.initialShips);
    }

    this.map.on('load', () => {
      this.mapLoaded = true;
      
      this.map.addSource('routes', {
        type: 'geojson',
        data: this.routeData || { type: 'FeatureCollection', features: [] }
      });

      this.map.addLayer({
        id: 'routes-layer',
        type: 'line',
        source: 'routes',
        layout: { 'line-join': 'round', 'line-cap': 'round' },
        paint: {
          'line-color': 'rgba(212, 175, 55, 0.1)',
          'line-width': 2,
          'line-dasharray': [2, 4]
        }
      });

      this.checkReady();
    });

    // 4. Handle Live Updates
    this.handleEvent("update_ships", ({ ships }) => {
      this.shipsToRender = ships;
      this.checkReady();
    });
  },

  checkReady() {
    if (this.mapLoaded && this.routeData && this.shipsToRender) {
      // Update the routes source if it was empty before
      const source = this.map.getSource('routes');
      if (source && source.serialize().data.features.length === 0) {
        source.setData(this.routeData);
      }
      this.updateShipMarkers(this.shipsToRender);
    }
  },

  updateShipMarkers(ships) {
    ships.forEach(ship => {
      const routeFeature = this.routeData.features.find(f => 
        (f.properties.from === ship.from && f.properties.to === ship.to) ||
        (f.properties.from === ship.to && f.properties.to === ship.from)
      );

      if (!routeFeature) return;

      const isReversed = routeFeature.properties.from === ship.to;
      const effectiveProgress = isReversed ? (1.0 - ship.progress) : ship.progress;

      const totalLen = length(routeFeature);
      const currentLen = totalLen * effectiveProgress;
      const currentPos = along(routeFeature, currentLen);
      const coords = currentPos.geometry.coordinates;

      const lookahead = Math.min(totalLen, currentLen + 0.1);
      const nextPos = along(routeFeature, lookahead);
      const angle = bearing(currentPos, nextPos);

      if (!this.shipMarkers[ship.id]) {
        const el = document.createElement('div');
        el.className = 'ship-marker';
        // Ensure no default styles interfere
        el.style.width = '30px';
        el.style.height = '30px';
        el.style.display = 'block';
        el.style.cursor = 'pointer';
        
        // Sailing Ship SVG (pointing North by default)
        el.innerHTML = `
          <svg viewBox="0 0 512 512" style="width: 30px; height: 30px; filter: drop-shadow(0 0 5px rgba(212, 175, 55, 0.8))">
            <path fill="#d4af37" d="M256 32l128 320H128L256 32z M256 384c-70.7 0-128 12.5-128 28v16c0 15.5 57.3 28 128 28s128-12.5 128-28v-16c0-15.5-57.3-28-128-28z"/>
          </svg>
        `;

        const popup = new maplibregl.Popup({ offset: 25 })
          .setHTML(`
            <div style="color: #050b14; padding: 5px;">
              <strong style="font-size: 1.1em;">${ship.name}</strong><br/>
              ${ship.from} &rarr; ${ship.to}<br/>
              Progress: ${Math.round(ship.progress * 100)}%
            </div>
          `);

        this.shipMarkers[ship.id] = new maplibregl.Marker({
          element: el,
          rotationAlignment: 'map'
        })
          .setLngLat(coords)
          .setRotation(angle)
          .setPopup(popup)
          .addTo(this.map);
      } else {
        this.shipMarkers[ship.id].setLngLat(coords);
        this.shipMarkers[ship.id].setRotation(angle);

        const popup = this.shipMarkers[ship.id].getPopup();
        if (popup) {
          popup.setHTML(`
            <div style="color: #050b14; padding: 5px;">
              <strong style="font-size: 1.1em;">${ship.name}</strong><br/>
              ${ship.from} &rarr; ${ship.to}<br/>
              Progress: ${Math.round(ship.progress * 100)}%
            </div>
          `);
        }
      }
      
      // Update title for tooltip
      this.shipMarkers[ship.id].getElement().title = `${ship.name} (${Math.round(ship.progress * 100)}%)`;
    });

    // Cleanup arrived ships
    const currentShipIds = ships.map(s => s.id);
    Object.keys(this.shipMarkers).forEach(id => {
      if (!currentShipIds.includes(id)) {
        this.shipMarkers[id].remove();
        delete this.shipMarkers[id];
      }
    });
  },

  destroyed() {
    if (this.map) this.map.remove();
  }
}
