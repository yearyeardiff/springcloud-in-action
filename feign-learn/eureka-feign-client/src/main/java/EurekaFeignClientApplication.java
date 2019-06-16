import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.context.annotation.ComponentScan;

/**
 *
 * spring cloud中discovery service有许多种实现（eureka、consul、zookeeper等等），@EnableDiscoveryClient基于spring-cloud-commons, @EnableEurekaClient基于spring-cloud-netflix。
 * 其实用更简单的话来说，就是如果选用的注册中心是eureka，那么就推荐@EnableEurekaClient，如果是其他的注册中心，那么推荐使用@EnableDiscoveryClient。
 *
 * 作者：Fredia_Wang
 * 链接：https://www.jianshu.com/p/f6db3117864f
 * 来源：简书
 * 简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
 *
 * @author zhangchenghao
 */
@SpringBootApplication
@EnableEurekaClient
@ComponentScan(basePackages={"provider"})
public class EurekaFeignClientApplication {
    public static void main(String[] args){
        new SpringApplicationBuilder(EurekaFeignClientApplication.class).web(true).run(args);
    }
}
