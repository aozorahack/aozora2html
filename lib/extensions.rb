# frozen_string_literal: true

# Kernel extension
module Kernel
  alias original_kernel_puts puts

  def puts(*args)
    original_kernel_puts(args)
  rescue Encoding::CompatibilityError
    original_kernel_puts(args.map { |arg| arg.force_encoding('utf-8') })
  end
end
