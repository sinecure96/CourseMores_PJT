package com.moham.coursemores.domain;

import com.moham.coursemores.domain.time.UpdateTimeEntity;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Entity
@Table(name = "theme")
@Getter
@ToString
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Theme extends UpdateTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "theme_id")
    private Long id;

    @NotNull
    @Column(length = 50)
    private String name;

    @OneToMany(mappedBy = "theme", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ThemeOfCourse> themeOfCourseList;

    @Builder
    public Theme(String name) {
        this.name = name;
    }

}