local DockerSetupStep(override) = {
  // extra environment vars
  extr_env:: {},
  extr_commands:: {},

  name: 'setup docker',
  pull: 'default',
  image: 'quay.io/presslabs/bfc',
  environment: {
    TAG_SUFFIX: '${DRONE_BRANCH/master/}',
    TEST_HOSTNAME: 'docker',
  } + self.extr_env,
  commands: [
    'dockerize -wait unix:///var/run/docker.sock -timeout 10s',
    'docker info',
  ] + self.extr_commands,
  volumes: [
    {
      name: 'dockersock',
      path: '/var/run',
    },
  ],
} + override;

local PublishPipeline(dir, name, depends_on=[]) = {
  kind: 'pipeline',
  name: name,
  steps: [
    DockerSetupStep({
      pull: 'always',
      extr_commands: [
        'make -C %s pull-$DRONE_STAGE_NAME' % dir,
      ],
    }),
    DockerSetupStep({
      name: 'build image',
      extr_env: {},
      commands: [
        'make -C %s $DRONE_STAGE_NAME' % dir,
      ],
    }),
    DockerSetupStep({
      name: 'test image',
      commands: [
        'make -C %s test-$DRONE_STAGE_NAME' % dir,
      ],
    }),
    DockerSetupStep({
      name: 'publish',
      extr_env: {
        DOCKER_USER: 'presslabs+drone',
        DOCKER_PASSWORD: {
          from_secret: 'QUAY_TOKEN',
        },
      },
      commands: [
        'docker login -u="$DOCKER_USER" -p="$DOCKER_PASSWORD" quay.io',
        'make -C %s push-$DRONE_STAGE_NAME' % dir,
      ],
    }),
  ],
  services: [
    {
      name: 'docker',
      image: 'docker:dind',
      privileged: true,
      volumes: [
        {
          name: 'dockersock',
          path: '/var/run',
        },
      ],
    },
  ],
  volumes: [
    {
      name: 'dockersock',
      temp: {},
    },
  ],
  depends_on: depends_on,
};


[
  PublishPipeline('php', 'php-runtime-7.2'),
  PublishPipeline('php', 'php-runtime-7.3'),
  PublishPipeline('php', 'php-runtime-7.4'),

  PublishPipeline('wordpress', 'wordpress-runtime-5.2', ['php-runtime-7.3']),
  PublishPipeline('wordpress', 'wordpress-runtime-5.3', ['php-runtime-7.3']),
  PublishPipeline('wordpress', 'wordpress-runtime-5.4', ['php-runtime-7.3']),

  PublishPipeline('wordpress', 'wordpress-runtime-bedrock', ['php-runtime-7.3']),
  PublishPipeline('wordpress', 'wordpress-runtime-bedrock-php-7.2', ['php-runtime-7.2']),
]
