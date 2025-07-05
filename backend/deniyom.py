import google.generativeai as genai

genai.configure(api_key="AIzaSyDYyzpRR-6odkx6Acik9X_VWmtwUz6Vkio")

models = genai.list_models()
for model in models:
    print(model.name)
