# docker-kaldi-android

Dockerfile for compiling Kaldi for Android. Based on instructions published at
http://jcsilva.github.io/2017/03/18/compile-kaldi-android/.

## Building

Run a container, mounting the Kaldi repository you just cloned to /opt/kaldi:

```
  $ git config --global core.autocrlf input
  $ git clone https://github.com/kaldi-asr/kaldi
  $ git clone https://github.com/janesser/docker-kaldi-android.git
  $ cd docker-kaldi-android
  $ docker build . -t janesser/docker-kaldi-android
  $ docker run -v $(pwd)/../kaldi:/opt/kaldi --rm janesser/docker-kaldi-android
```

When ``docker run`` finishes, all the compiled Android binaries will be located
in ``../kaldi/src`` subdirectories.
