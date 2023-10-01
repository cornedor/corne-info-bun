@react.component
let make = () => {
  <>
    <p>
      {React.string(`Here is a simple setup that can be used to self-host a docker registry.
        It is fine when you only need to host a few personal images. But since
        auth is done via basic auth, it is hard to manage extra users.`)}
    </p>
    <pre className="mb-4 overflow-auto rounded border-stone-200 bg-stone-50 p-2 shadow-md">
      {React.string(`version: '3'

services:
  traefik:
    image: traefik:v2.9
    networks:
      proxy:
    ports:
      # The HTTP port
      - '80:80'
      - '443:443'
      # The Web UI (enabled by --api.insecure=true)
      - '8080:8080'
      # Metrics
      - '3880:3880'
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik:/etc/traefik/

  registry:
    image: registry:2
    networks:
      proxy:
    restart: always
    ports:
      - 5000:5000
    volumes:
      - ./registry:/var/lib/registry
    environment:
      REGISTRY_HTTP_ADDR: '0.0.0.0:5000'
    labels:
      - traefik.http.routers.registry.rule=Host(\`registry.example.com\`)
      - traefik.http.routers.registry.tls=true
      - traefik.http.routers.registry.tls.certresolver=letsencrypt
      - traefik.http.routers.registry.tls.domains[0].main=registry.example.com
      - traefik.http.middlewares.dockerHeader.headers.customResponseHeaders.Docker-Distribution-Api-Version=registry/2.0
      - traefik.http.middlewares.dockerAuth.basicAuth.users=corne:********************
      - traefik.http.routers.registry.middlewares=dockerHeader,dockerAuth

networks:
  proxy:`)}
    </pre>
  </>
}

let config: Page.pageConfig = {
  title: "Template",
}
