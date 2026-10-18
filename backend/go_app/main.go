package main

import (
	"net/http"
	"github.com/gin-gonic/gin"
)

type UserProfile struct {
	ID           string `json:"id"`
	Username     string `json:"username"`
	Bio          string `json:"bio"`
	FriendsCount int    `json:"friends_count"`
	Initial      string `json:"initial"`
}

func GetProfile(c *gin.Context) {
	userId := c.Param("id")

	// В будущем здесь будет запрос к PostgreSQL
	// Пока отдаем моковые данные, чтобы UI ожил
	profile := UserProfile{
		ID:           userId,
		Username:     "maksim_ph",
		Bio:          "Мы пока ничего не знаем об этом пользователе...",
		FriendsCount: 38,
		Initial:      "A",
	}

	c.JSON(http.StatusOK, profile)
}

func main() {
	r := gin.Default()

	// Разрешаем CORS для тестов (если понадобится)
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Next()
	})

	api := r.Group("/api/users")
	{
		api.GET("/:id/profile", GetProfile)
	}

	// Запускаем на порту 8080 (Python у нас обычно на 8000)
	r.Run(":8080")
}