git init
git add .
git commit -m "First commit"
git remote add origin <SSH на репозиторий>
# # Если загружаем в другую ветку
# git checkout -b <Название ветки>
# git --set --upstream <Название ветки>
git push -u origin master