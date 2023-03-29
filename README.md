# Shiny GPT Demo

I asked ChatGPT to make me a little Issue Management Shiny App. Here's how it went!

![image](https://user-images.githubusercontent.com/3680095/228610405-5450b0f5-1fde-43d6-a45a-ca40a614a02c.png)

# Prompt 1: make me an R shiny app that implements a basic issue management system 

Made an app that runs ([code](https://github.com/jwildfire/shiny-gpt-demo/blob/main/app_v1.r)) but, didn't actually populate the UI :( 

![image](https://user-images.githubusercontent.com/3680095/228597247-b83dfb45-3e8c-4dce-b7a3-3654e0e46f0e.png)

![image](https://user-images.githubusercontent.com/3680095/228597088-7c87bd7f-016a-4bdd-a5e0-e24e5015a1c7.png)

# Prompt 2: update the app so that i can edit existing issues

This triggered updates in the UI [code](https://github.com/jwildfire/shiny-gpt-demo/blob/main/app_v2.r)!

![0837a7a8-ae53-468e-b402-f992107d15d2](https://user-images.githubusercontent.com/3680095/228607383-bc48468d-bd99-406c-a83b-8267763d4f9b.jpg)
![5991868a-5334-49d6-a85f-1242ba79da3f](https://user-images.githubusercontent.com/3680095/228607385-72211d99-5448-4c65-bc7f-b06ffe73f713.jpg)

And it added some javascript in datatables to make that table editable.
![b9137b11-4616-477e-b592-db0d924fc5da](https://user-images.githubusercontent.com/3680095/228607609-627eff17-0ba5-4dfb-8499-3aa0f3e51b6f.jpg)
![c175c225-ed25-4114-ac46-ae881c2136ee](https://user-images.githubusercontent.com/3680095/228607611-80935a72-f31e-4f2e-b7c2-3c1a08137679.jpg)

At this point we've got a functional little prototype. Let's see if we can do more ... 

# Prompt 3: implement a simple database store the issues

This one only gave a partial server function so I went with ...

# Prompt 4: The server function doesn't have a closing curly bracket. fix that please. 

[Code](https://github.com/jwildfire/shiny-gpt-demo/blob/main/app_v3_4.r) still doesn't run. Looks like the onStartup function has syntax issues.

![Screen Shot 2023-03-29 at 3 36 42 PM](https://user-images.githubusercontent.com/3680095/228648820-7935e23c-993b-425a-b36d-3b98d1bd2d99.png)

Let's see if it can fix it ... 

# Prompt 5: onStartup() throws a syntax error. make sure to define it as an R function.


