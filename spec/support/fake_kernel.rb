class FakeKernel
  attr_reader :exit_status

  def system(*args)
    system_commands.push(args.join(' '))
  end

  def system_commands
    @system_commands ||= []
  end

  def abort(msg)
    self.exit(false)
    #exit(false)
  end

  def exit(whatevs)
    whatevs = -1 unless whatevs.is_a?(Integer)
    @exit_status ||= whatevs
  end
end
