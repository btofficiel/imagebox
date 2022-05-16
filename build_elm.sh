cd elm
bash ./optimized.sh src/Main.elm build/elm.min.js
mv build/elm.min.js ../static/js/
rm -rf build
cd ../
