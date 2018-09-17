from setuptools import setup, find_packages

setup(name='Cyanodbc',
      version='0.0.1',
      package_dir={ '': '.' },
      package_data={'cyanodbc':['*.*']},
      packages=['cyanodbc'])
