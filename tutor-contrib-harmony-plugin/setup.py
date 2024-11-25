import io
import os

from setuptools import find_packages, setup

HERE = os.path.abspath(os.path.dirname(__file__))


def load_readme():
    with io.open(os.path.join(HERE, "README.rst"), "rt", encoding="utf8") as f:
        return f.read()


def load_about():
    about = {}
    with io.open(
        os.path.join(HERE, "tutor_k8s_harmony_plugin", "__about__.py"),
        "rt",
        encoding="utf-8",
    ) as f:
        exec(f.read(), about)  # pylint: disable=exec-used
    return about


ABOUT = load_about()


setup(
    name="tutor-contrib-harmony",
    version=ABOUT["__version__"],
    url="https://github.com/openedx/openedx-k8s-harmony",
    project_urls={
        "Code": "https://github.com/openedx/openedx-k8s-harmony",
        "Issue tracker": "https://github.com/openedx/openedx-k8s-harmony/issues",
    },
    license="AGPLv3",
    author="Braden MacDonald",
    description="multi instance k8s plugin for Tutor",
    long_description=load_readme(),
    packages=find_packages(exclude=["tests*"]),
    include_package_data=True,
    python_requires=">=3.8",
    install_requires=["tutor>=17.0.0,<19.0.0"],
    entry_points={
        "tutor.plugin.v1": [
            "k8s_harmony = tutor_k8s_harmony_plugin.plugin",
        ]
    },
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: GNU Affero General Public License v3",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
)
