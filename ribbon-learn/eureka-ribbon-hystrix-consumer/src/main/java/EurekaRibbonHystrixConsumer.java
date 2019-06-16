import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.client.circuitbreaker.EnableCircuitBreaker;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.context.annotation.ComponentScan;

/**
 * @author zhangchenghao
 */
@EnableEurekaClient
@SpringBootApplication
@EnableCircuitBreaker
@ComponentScan(basePackages={"consumer", "config"})

public class EurekaRibbonHystrixConsumer {

    public static void main(String[] args){
        new SpringApplicationBuilder(EurekaRibbonHystrixConsumer.class).web(true).run(args);
    }
}
