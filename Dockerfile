FROM python:3
RUN apt-get update && apt-get install -y python3-pygame
COPY . /app
WORKDIR /app
CMD ["python3", "snake_game.py"]

#docker build -t snake-game .
#docker run -p 5000:5000 snake-game