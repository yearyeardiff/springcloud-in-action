package consumer;

import feign.hystrix.FallbackFactory;
import org.springframework.stereotype.Component;

/**
 * @author zhangchenghao
 */
@Component
public class HelloServiceClientHystrixFactory implements FallbackFactory<HelloServiceClient> {
    @Override
    public HelloServiceClient create(Throwable throwable) {
        return new HelloServiceClient() {
            @Override
            public String hello(String name) {
                throwable.printStackTrace();
                return "fallback; reason was: " + throwable.getMessage();
            }
        };
    }
}
