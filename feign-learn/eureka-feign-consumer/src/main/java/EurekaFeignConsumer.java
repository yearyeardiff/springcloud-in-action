import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.client.circuitbreaker.EnableCircuitBreaker;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.netflix.feign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;

/**
 * @author zhangchenghao
 */
@EnableFeignClients
@EnableEurekaClient
@SpringBootApplication
@ComponentScan(basePackages={"consumer"})
public class EurekaFeignConsumer {

    public static void main(String[] args){
        new SpringApplicationBuilder(EurekaFeignConsumer.class).web(true).run(args);
    }
}
