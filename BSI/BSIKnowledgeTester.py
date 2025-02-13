import tkinter as tk
from tkinter import messagebox
import json
import random

# Funkcja do załadowania pytań z pliku JSON
def load_questions(file_path):
    with open(file_path, "r") as file:
        return json.load(file)

# Funkcja do rozpoczęcia nowej gry
def start_game():
    global current_question_index, score, questions
    current_question_index = 0
    score = 0
    # Wybierz losowe 10 pytań z zestawu
    #selected_questions = random.sample(full_question_set, 5)
    selected_questions = random.sample(full_question_set, 30)
    questions.clear()
    questions.extend(selected_questions)
    show_question()

# Funkcja do wyświetlenia pytania
def show_question():
    global current_question_index, selected_answers
    if current_question_index < len(questions):
        question_data = questions[current_question_index]
        question_label.config(text=question_data["question"], fg="black", bg="white", font=("Arial", 20))
        selected_answers = []
        for i in range(8):
            if i < len(question_data["answers"]):
                answer = question_data["answers"][i]
                answer_buttons[i].config(text=answer, bg="white", state="normal", fg="black")
                answer_buttons[i].deselect()
            else:
                answer_buttons[i].config(text='', state="disabled", bg="white", fg="black")
        selected_answers = []
    else:
        show_result()

# Funkcja do sprawdzenia odpowiedzi
def check_answer():
    global current_question_index, score
    question_data = questions[current_question_index]
    correct_answers = set(question_data["correct"])
    selected = set(selected_answers)
    
    for i, button in enumerate(answer_buttons):
        if i in correct_answers:
            button.config(bg="green")
        elif i in selected:
            button.config(bg="red")

    if correct_answers == selected:
        score += 1

    current_question_index += 1
    root.after(2000, show_question)

# Funkcja do obsługi zaznaczania odpowiedzi
def select_answer(index):
    if index in selected_answers:
        selected_answers.remove(index)
    else:
        selected_answers.append(index)

# Funkcja do wyświetlenia wyniku
def show_result():
    messagebox.showinfo("Result", f"Your score: {score}/{len(questions)}")
    start_game()

# Ładowanie wszystkich pytań
full_question_set = load_questions("questions.json")
questions = []

# Inicjalizacja GUI
root = tk.Tk()
root.title("Knowledge Tester")
root.geometry("1000x800")
root.configure(bg="white")  # Ustawienie białego tła dla okna głównego

question_label = tk.Label(root, text="", wraplength=400, fg="black", bg="white", font=("Arial", 14))
question_label.pack(pady=20)

answer_buttons = []
selected_answers = []

for i in range(8):
    var = tk.IntVar()
    button = tk.Checkbutton(root, text="", variable=var, font=("Arial", 12), fg="black", bg="white", command=lambda i=i: select_answer(i))
    button.pack(anchor="w", padx=20, pady=5)
    answer_buttons.append(button)

check_button = tk.Button(root, text="Submit Answer", command=check_answer, fg="black", bg="white")
check_button.pack(pady=20)

start_game()

root.mainloop()
