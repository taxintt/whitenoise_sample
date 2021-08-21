from django.shortcuts import render
from django.views import generic

from .models import Blog

# Create your views here.
class IndexView(generic.ListView):
    template_name = 'blog/index.html'
    queryset = Blog.objects.all()
