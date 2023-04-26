package com.moham.coursemores.api;

import com.moham.coursemores.dto.profile.UserInfoResDto;
import com.moham.coursemores.dto.profile.UserInfoUpdateReqDto;
import com.moham.coursemores.service.ProfileService;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("profile")
@RequiredArgsConstructor
public class ProfileController {

    private static final Logger logger = LoggerFactory.getLogger(ProfileController.class);

    private final ProfileService profileService;

    @GetMapping("{userId}")
    public ResponseEntity<Map<String, Object>> myProfile(@PathVariable int userId) {

        logger.info(">> request : userId={}", userId);

        Map<String, Object> resultMap = new HashMap<>();

        UserInfoResDto result = profileService.getMyProfile(userId);
        resultMap.put("userInfo", result);
        logger.info("<< response : test={}", result);


        return new ResponseEntity<>(resultMap, HttpStatus.OK);
    }

    @PutMapping("{userId}/alram")
    public ResponseEntity<Void> alarmSetting(@PathVariable int userId){
        logger.info(">> request : userId={}", userId);
        
        // 알림 셋팅

        logger.info("<< response : none");

        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PutMapping("{userId}")
    public ResponseEntity<Void> putUserInfo(@PathVariable int userId, @RequestBody UserInfoUpdateReqDto userInfoUpdateReqDto){
        logger.info(">> request : userId={}, userInfoUpdateReqDto={}", userId, userInfoUpdateReqDto);

        profileService.updateUserInfo(userId, userInfoUpdateReqDto);
        logger.info("<< response : none");

        return new ResponseEntity<>(HttpStatus.OK);
    }

    @GetMapping("logout")
    public ResponseEntity<Void> logout() {
        // 로그아웃 처리
        
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @DeleteMapping("{userId}")
    public ResponseEntity<Void> deleteUser(@PathVariable int userId){
        logger.info(">> request : userId={}", userId);

        profileService.deleteUser(userId);
        logger.info("<< response : none");

        return new ResponseEntity<>(HttpStatus.OK);
    }
}
