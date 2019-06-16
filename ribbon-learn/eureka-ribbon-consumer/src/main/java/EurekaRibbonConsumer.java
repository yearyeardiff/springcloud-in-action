import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.netflix.feign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;

/**
 * @author zhangchenghao
 */
@EnableEurekaClient
@SpringBootApplication
@ComponentScan(basePackages={"consumer", "config"})
public class EurekaRibbonConsumer {

    public static void main(String[] args){
        new SpringApplicationBuilder(EurekaRibbonConsumer.class).web(true).run(args);
    }
}
