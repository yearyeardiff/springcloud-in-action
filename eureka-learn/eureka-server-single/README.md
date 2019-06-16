In standalone mode, you might prefer to switch off the client side behaviour, so it doesn’t keep trying and failing to reach its peers. Example:

application.yml (Standalone Eureka Server). 

```yaml
server:
  port: 8761

eureka:
  instance:
    hostname: localhost
  client:
    # 单例设置false
    registerWithEureka: false
    fetchRegistry: false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
```