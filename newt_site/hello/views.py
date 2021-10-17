from django.http import HttpResponse

def index(request):
    return HttpResponse("Hello, world. You're in the newt project at the Hello App index (views.py).")
