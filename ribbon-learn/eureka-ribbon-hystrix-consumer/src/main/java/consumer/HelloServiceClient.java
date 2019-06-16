package consumer;

import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * @author zhangchenghao
 */
@Service
public class HelloServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    @HystrixCommand(fallbackMethod = "addServiceFallback")
    public String hello(String name){
        return restTemplate.getForObject("http://eureka-feign-client/hello?name={1}", String.class, name);
    }

    /**
     * 主逻辑中会主动抛出一个异常，从而触发该主逻辑的降级函数fallback。重点看fallback函数中的最后一个传参Throwable throwable。
     * 通过这样的简单定义，开发人员就可以很方便的获取触发降级逻辑的异常信息，用作日志记录或者其它复杂的业务逻辑了
     * @param name
     * @param throwable
     * @return
     */
    public String addServiceFallback(String name,Throwable throwable) {
        throwable.printStackTrace();
        return "error:" + throwable.getCause();
    }

}
