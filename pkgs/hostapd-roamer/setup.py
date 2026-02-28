from setuptools import find_packages, setup

setup(
    name="hostapdRoamer",
    version="0.1.0",
    # Modules to import from other scripts:
    packages=find_packages(),
    py_modules=["access_point", "hostapd", "wpaspy"],
    # Executables
    scripts=["main.py"],
)
