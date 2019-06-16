package consumer;

import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author zhangchenghao
 */
@Component
public class HelloServiceClientHystrix implements HelloServiceClient{
    @Override
    public String hello(@RequestParam(value = "name") String name) {
        return "error happened";
    }

}
