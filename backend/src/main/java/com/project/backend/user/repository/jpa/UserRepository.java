package com.project.backend.user.repository.jpa;

import com.project.backend.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
  Optional<User> findByUsername(String username);
  Optional<User> findByEmail(String email);
  Optional<User> findBySocialId(Long socialId);
  Optional<User> findByPhone(String phone);
  Optional<User> findByNickname(String nickname);
}
